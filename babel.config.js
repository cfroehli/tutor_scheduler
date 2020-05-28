function isDevelopmentEnv(api) { return api.env('development'); }
function isProductionEnv(api) { return api.env('production'); }
function isTestEnv(api) { return api.env('test'); }

function gen_presets_list(api) {
  return [
    isTestEnv(api) && [
        '@babel/preset-env',
        {
          targets: {
            node: 'current'
          }
        }
      ],
    (isProductionEnv(api) || isDevelopmentEnv(api)) && [
        '@babel/preset-env',
        {
          forceAllTransforms: true,
          useBuiltIns: 'entry',
          corejs: 3,
          modules: false,
          exclude: ['transform-typeof-symbol']
        }
      ]
  ].filter(Boolean);
}

function gen_plugins_list(api) {
  return [
      'babel-plugin-macros',
      '@babel/plugin-syntax-dynamic-import',
      isTestEnv(api) && 'babel-plugin-dynamic-import-node',
      '@babel/plugin-transform-destructuring',
      [ '@babel/plugin-proposal-class-properties', { loose: true } ],
      [ '@babel/plugin-proposal-object-rest-spread', { useBuiltIns: true } ],
      [ '@babel/plugin-transform-runtime', { helpers: false, regenerator: true, corejs: false } ],
      [ '@babel/plugin-transform-regenerator', { async: false } ]
  ].filter(Boolean);
}

module.exports = function(api) {
  var validEnv = ['development', 'test', 'production'];
  var currentEnv = api.env();
  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      'Please specify a valid `NODE_ENV` or ' +
        '`BABEL_ENV` environment variables. Valid values are "development", ' +
        '"test", and "production". Instead, received: ' +
        JSON.stringify(currentEnv) + '.'
    );
  }

  return {
    presets: gen_presets_list(api),
    plugins: gen_plugins_list(api)
  };
};
