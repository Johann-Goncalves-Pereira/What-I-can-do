const path = require("path");
const merge = require("webpack-merge");
const common = require("./webpack.common.js");
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = merge(common, {
  mode: "production",
  output: {
    filename: "index.[contentHash].js",
    path: path.join(__dirname, "public"),
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: {
            optimize: true,
          },
        },
      },
      {
        test: /\.s[ac]ss$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          // fallback to style-loader in development
          MiniCssExtractPlugin.loader,
          "css-loader",
          "postcss-loader",
          "sass-loader",
        ],
      },
    ],
  },
  devtool: "source-map",
  plugins: [
    new webpack.DefinePlugin({
      ENV: '"Production mode!"',
    }),
  ],
});
