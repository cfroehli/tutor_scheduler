const { environment } = require('@rails/webpacker');

const webpack = require('webpack');

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jquery: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default'],
    Moment: 'moment',
    moment: 'moment'
  }));

environment.config.merge({
  optimization: {
    runtimeChunk: 'single',
    splitChunks: {
      chunks: 'all',
        maxInitialRequests: Infinity,
      minSize: 0,
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name(module) {
            const packageName = module.context.match(/[\\/]node_modules[\\/](.*?)([\\/]|$)/)[1];
            return `npm.${packageName.replace('@', '')}`;
          }
        }
      }
    }
  }
});

console.log(environment);

module.exports = environment;
