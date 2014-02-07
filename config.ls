const NODE_ENV = process.env.NODE_ENV
npmConfig = (name) -> process.env["npm_package_config_#{name}"]
openshiftConfig = (name) -> process.env["OPENSHIFT_#{name}"]

module.exports =
  if \npm_package_config_override_config of process.env
    # npm-overridden environment
    ENVIRONMENT:     NODE_ENV or npmConfig \environment
    SERVER_ADDRESS:  npmConfig \host or void
    SERVER_PORT:     npmConfig \port
  else if \OPENSHIFT_APP_NAME of process.env
    # OpenShift (production) environment
    ENVIRONMENT:     NODE_ENV or \production
    SERVER_ADDRESS:  openshiftConfig \NODEJS_IP
    SERVER_PORT:     openshiftConfig \NODEJS_PORT
  else
    # Local (development) environment
    ENVIRONMENT:     NODE_ENV or \development
    SERVER_ADDRESS:  'localhost'
    SERVER_PORT:     8080
