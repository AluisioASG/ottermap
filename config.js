var NODE_ENV = process.env.NODE_ENV;
var npmConfig = function (name) {
  return process.env['npm_package_config_' + name];
};
var openshiftConfig = function (name) {
  return process.env['OPENSHIFT_' + name];
};

if ('npm_package_config_override_config' in process.env) {
  // npm-overridden environment
  exports.ENVIRONMENT    = NODE_ENV || npmConfig('environment');
  exports.SERVER_ADDRESS = npmConfig('host') || undefined;
  exports.SERVER_PORT    = npmConfig('port');
}
else if ('OPENSHIFT_APP_NAME' in process.env) {
  // OpenShift (production) environment
  exports.ENVIRONMENT    = NODE_ENV || 'production';
  exports.SERVER_ADDRESS = openshiftConfig('NODEJS_IP');
  exports.SERVER_PORT    = openshiftConfig('NODEJS_PORT');
} else {
  // Local (development) environment
  exports.ENVIRONMENT    = NODE_ENV || 'development';
  exports.SERVER_ADDRESS = 'localhost';
  exports.SERVER_PORT    = 8080;
}
