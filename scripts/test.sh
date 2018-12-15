#!/bin/bash

set -e

# Set java version 11
JAVA_HOME=$(/usr/libexec/java_home -v 11)

# Figure out test classpath
mvn dependency:build-classpath -DincludeScope=test -Dmdep.outputFile=cp.txt

# Run all tests directly
java -cp $(cat cp.txt):$(pwd)/target/classes:$(pwd)/target/test-classes org.junit.runner.JUnitCore \
org.javacs.ArtifactTest \
org.javacs.ClassesTest \
org.javacs.CodeLensTest \
org.javacs.CompletionsScopesTest \
org.javacs.CompletionsTest \
org.javacs.DocsTest \
org.javacs.FindReferencesTest \
org.javacs.GotoTest \
org.javacs.InferBazelConfigTest \
org.javacs.InferConfigTest \
org.javacs.JavaCompilerServiceTest \
org.javacs.ParserFixImportsTest \
org.javacs.ParserTest \
org.javacs.PrunerTest \
org.javacs.SearchTest \
org.javacs.SignatureHelpTest \
org.javacs.SymbolUnderCursorTest \
org.javacs.TipFormatterTest \
org.javacs.UrlsTest 