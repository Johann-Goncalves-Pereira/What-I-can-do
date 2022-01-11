function requireAll(r) {
  r.keys().forEach(r);
}

requireAll(require.context("../Stylesheet", true, /\.*/));
requireAll(require.context("../Stylesheet/base/", true, /\.*/));
requireAll(require.context("../Stylesheet/abstracts", true, /\.*/));
