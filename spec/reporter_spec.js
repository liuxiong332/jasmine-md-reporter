
describe('Hello', function() {
  it('sets the started_ field to true', function() {
    expect('Hello').toBeTruthy();
  });

  it('buildes the suites_ collection', function() {
    expect('Hello').toEqual('Hello');
    expect('world').toEqual('world');
  });

  // xdescribe('not able describe', function() {
  //   it('it in describe', function() {
  //     expect('Hello').toEqual('Hello');
  //     expect('world').toEqual('world');
  //   });
  // });

  xit('good Hello', function() {
    expect('dd').toEqual('dd');
  });

  // fit('focus good Hello', function() {
  //   expect('dd').toEqual('dd');
  // });

  xdescribe('just for fun', function() {
    it('fun in fun', function() {
      expect('hello').toEqual('hello');
    });

    xit('focus in fun', function() {
      expect('hello').toEqual('hello');
    });

    describe('ddd', function() {
      it('mmm', function() {
        expect('hello').toEqual('hello');
      });
    });
  });
});
