casper.test.begin('Search for music', 2, function suite(test) {
  var baseUrl = casper.cli.options.base || 'http://localhost:8000';

  console.log(baseUrl);
  casper.start(baseUrl, function() {
      test.assertTitle('Music Search Buddy');
  });

  casper.then(function() {
    this.fillSelectors('form#search', {
      'input[name="q"]': 'blackfield'
    }, false);
  });

  casper.waitForSelector('.albums ul', function() {
    test.assert(this.exists('.meta .artist'), 'Renders at least one album');
  });

  casper.run(function() {
    test.done();
  });
});
