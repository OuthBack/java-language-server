package org.javacs.markup;

import com.sun.source.tree.IfTree;
import com.sun.source.tree.Tree;
import com.sun.source.util.JavacTask;
import com.sun.source.util.TreePath;
import com.sun.source.util.TreeScanner;
import com.sun.source.util.Trees;

import javax.lang.model.element.Element;
import java.util.*;

interface  IfStatements {
    void setIfStatements(IfTree element);
}

class WarnCondition extends TreeScanner<Void, Void> {
    // Copied from TreePathScanner
    // We need to be able to call scan(path, _) recursively
    private TreePath path;
    private final Trees trees;
    private Tree tree;

    HashMap<TreePath, String> conditionPaths = new HashMap<>();

    WarnCondition(JavacTask task) {
        this.trees = Trees.instance(task);
    }

    private void scanPath(TreePath path) {
        TreePath prev = this.path;
        this.path = path;
        try {
            path.getLeaf().accept(this, null);
        } finally {
            this.path = prev; // So we can call scan(path, _) recursively
        }
    }

    @Override
    public Void scan(Tree tree, Void p) {
        if (tree == null) return null;

        TreePath prev = path;
        path = new TreePath(path, tree);
        this.tree = tree;
        try {
            return tree.accept(this, p);
        } finally {
            path = prev;
        }
    }

    @Override
    public Void visitIf(IfTree node, Void p) {
        String expression = node.getCondition().toString();

        if(expression.length() < 2){
            return super.visitIf(node, p);
        }

        String removedParethesisExpression = expression.substring(1, expression.length() - 1);
        checkExpression(removedParethesisExpression);

        return super.visitIf(node, p);
    }

    public HashMap<TreePath, String> getConditionPaths(){
        return conditionPaths;
    }

    private void checkExpression(String expression) {

        switch (expression){
            case "true", "false":
                conditionPaths.put(path, expression);
                break;
        }

    }

}
