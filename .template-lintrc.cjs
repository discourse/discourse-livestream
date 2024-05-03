const baseConfig = require("@discourse/lint-configs/template-lint");

module.exports = {
  ...baseConfig,
  ignore: [
    ...(Array.isArray(baseConfig.ignore) ? baseConfig.ignore : []),
    'assets/javascripts/discourse/components/streamer',
  ],
};
