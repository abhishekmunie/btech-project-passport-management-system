require('newrelic');
console.time('Config');
require('./lib/app');
console.timeEnd('Config');
