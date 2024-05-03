const baseConfig = require("@discourse/lint-configs/eslint");

baseConfig.globals = {
  ...baseConfig.globals,
  "mux-player": "readonly",
};

module.exports = baseConfig;
