const { environment } = require('@rails/webpacker')

// https://github.com/rails/webpacker/issues/1119
environment.loaders.get('sass').use.splice(-1, 0, {
  loader: 'resolve-url-loader'
});

module.exports = environment
