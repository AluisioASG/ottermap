var NODE_ENV = process.env.NODE_ENV;

if ('OPENSHIFT_APP_NAME' in process.env) {
  // OpenShift (production) environment
  exports.ENVIRONMENT    = NODE_ENV || 'production';
  exports.SERVER_ADDRESS = process.env['OPENSHIFT_NODEJS_IP'];
  exports.SERVER_PORT    = process.env['OPENSHIFT_NODEJS_PORT'];
} else {
  // Local (development) environment
  exports.ENVIRONMENT    = NODE_ENV || 'development';
  exports.SERVER_ADDRESS = 'localhost';
  exports.SERVER_PORT    = 8080;
}
