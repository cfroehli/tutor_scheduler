const { environment } = require('@rails/webpacker');

const webpack = require('webpack');

environment.plugins.append(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default'],
    Moment: 'moment',
    moment: 'moment'
  }));

environment.loaders.prepend(
  'jQueryExpose',
  {
    test: require.resolve('jquery'),
    use: [ { loader: 'expose-loader', options: '$' },
           { loader: 'expose-loader', options: 'jQuery' },
         ]
  }
);

environment.loaders.append(
  'jQuery@multiselect',
  {
    test: require.resolve('bootstrap-multiselect'),
    use: [ { loader: 'imports-loader', options: '$=jquery' },
           { loader: 'imports-loader', options: 'jQuery=jquery' },
           { loader: 'imports-loader', options: 'this=>window' }
         ]
  }
);

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

module.exports = environment;
