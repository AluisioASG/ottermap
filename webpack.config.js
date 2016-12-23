const {gitDescribeSync} = require('git-describe')
const webpack = require('webpack')
const ExtractTextWebpackPlugin = require('extract-text-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')


module.exports = {
  entry: {
    app: './src/js/main',
    style: './src/css/main',
  },
  output: {
    path: `${__dirname}/build`,
    filename: 'js/[name].js',
  },
  resolve: {
    extensions: ['', '.ts', '.js', '.styl', '.css'],
    modulesDirectories: ['vendor'],
    alias: {
      'bootstrap': 'bootstrap/css',
      'cssanimevent': 'cssanimevent/cssanimevent',
      'leaflet.style': 'leaflet/dist',
      'leaflet-geosearch.js': 'leaflet-geosearch/src/js',
    },
  },
  devtool: 'source-map',

  module: {
    loaders: [
      {test: /\.ts$/, loader: 'ts-loader'},
      {test: /\.css$/, loader: ExtractTextWebpackPlugin.extract('style-loader', 'css-loader')},
      {test: /\.(png|gif|svg)$/, loader: 'file-loader?name=img/[hash].[ext]&publicPath=../'},
      {test: /\.(ttf|woff2?)$/, loader: 'file-loader?name=fonts/[hash].[ext]&publicPath=../'},
    ],
  },

  plugins: [
    new webpack.ResolverPlugin(
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin('bower.json', ['main', 'loader'])
    ),
    new HtmlWebpackPlugin({
      filename: 'index.html',
      template: './src/index.html',
      excludeChunks: ['css-only'],
      packageVersion: version(),
    }),
    new ExtractTextWebpackPlugin('css/[name].css')
  ],
}

// Determine the package version
function version() {
  try {
    const desc = gitDescribeSync(__dirname)
    return desc.distance == 0 ? desc.tag : `${desc.tag}+${desc.distance}`
  } catch (ex) {
    // Fall back to package.json
    const ver = require('./package.json').version
    return `v${ver}`
  }
}