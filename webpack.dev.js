const merge = require("webpack-merge");
const common = require("./webpack.common.js");
const path = require("path");
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CleanTerminalPlugin = require("clean-terminal-webpack-plugin");

const HOST = "0.0.0.0";
const PORT = 8080;

module.exports = merge(common, {
  mode: "development",
  output: {
    filename: "index.bundle.js",
    publicPath: "/",
    path: path.resolve(__dirname, "public"),
  },
  plugins: [
    new webpack.DefinePlugin({
      ENV: '"Development mode!"',
    }),
    new CleanTerminalPlugin({
      message: `                 Dev server running on http://${HOST}:${PORT}`,
      beforeCompile: true,
    }),
  ],
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          { loader: "elm-hot-webpack-loader" },
          {
            loader: "elm-webpack-loader",
            options: {
              debug: true,
              verbose: true,
              forceWatch: true,
            },
          },
        ],
      },
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader", "postcss-loader", "postcss-loader"],
      },
      {
        test: /\.s(a|c)ss$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: ["style-loader", "css-loader", "postcss-loader", "sass-loader"],
      },
    ],
  },
  devServer: {
    host: "0.0.0.0",
    disableHostCheck: true,
    inline: true,
    stats: "errors-only",
    contentBase: path.join(__dirname, "public"),
    historyApiFallback: true,
    overlay: true,
    hot: true,
  },
  devtool: "inline-source-map",
});
