package org.javacs;

import com.google.common.reflect.ClassPath;

import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.Modifier;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Index the classpath *without* using the java compiler API.
 * The classpath can contain problematic types, for example references to classes that *aren't* present.
 * So we use reflection to find class names and constructors on the classpath.
 *
 * The isn't the only way we inspect the classpath---when completing members, for example, we use the Javac API.
 * This path is strictly for when we have to search the *entire* classpath.
 */
class ClassPathIndex {

    private final List<ClassPath.ClassInfo> topLevelClasses;

    ClassPathIndex(Set<Path> classPath) {
        ClassPath reflect = classPath(classPath);

        this.topLevelClasses = reflect.getTopLevelClasses()
                .stream()
                .collect(Collectors.toList());
    }

    private static ClassPath classPath(Set<Path> classPath) {
        URL[] urls = classPath.stream()
                .flatMap(ClassPathIndex::url)
                .toArray(URL[]::new);

        try {
            return ClassPath.from(new URLClassLoader(urls));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private static Stream<URL> url(Path path) {
        try {
            return Stream.of(path.toUri().toURL());
        } catch (MalformedURLException e) {
            LOG.warning(e.getMessage());

            return Stream.empty();
        }
    }

    private static boolean isPublic(ClassPath.ClassInfo info) {
        return tryLoad(info)
                .map(c -> Modifier.isPublic(c.getModifiers()))
                .orElse(false);
    }

    private static Optional<Class<?>> tryLoad(ClassPath.ClassInfo info) {
        try {
            return Optional.of(info.load());
        } catch (LinkageError e) {
            LOG.warning(e.getMessage());

            return Optional.empty();
        }
    }

    /**
     * Find all top-level classes accessible from `fromPackage`
     */
    Stream<ClassPath.ClassInfo> topLevelClasses(String fromPackage) {
        return topLevelClasses.stream()
                .filter(info -> isPublic(info) || isInPackage(info, fromPackage));
    }

    private boolean isInPackage(ClassPath.ClassInfo info, String fromPackage) {
        return tryLoad(info)
                .map(c -> c.getPackage().getName().equals(fromPackage))
                .orElse(false);
    }

    /**
     * Find all constructors in top-level classes accessible to any class in `fromPackage`
     */
    Stream<Constructor<?>> topLevelConstructors(String fromPackage) {
        return topLevelClasses(fromPackage)
                .flatMap(this::explodeConstructors);
    }

    private Stream<Constructor<?>> explodeConstructors(ClassPath.ClassInfo classInfo) {
        return tryLoad(classInfo)
                .map(c -> constructors(c))
                .orElseGet(Stream::empty)
                .filter(cons -> isAccessible(cons));
    }

    private Stream<Constructor<?>> constructors(Class<?> c) {
        try {
            return Arrays.stream(c.getConstructors());
        } catch (LinkageError e) {
            LOG.warning(e.getMessage());

            return Stream.empty();
        }
    }

    private boolean isAccessible(Constructor<?> cons) {
        return !Modifier.isPrivate(cons.getModifiers()) && !Modifier.isProtected(cons.getModifiers());
    }

    private static final Logger LOG = Logger.getLogger("main");
}
