
describe('Hello', function() {
  it('sets the started_ field to true', function() {
    expect('Hello').toBeTruthy();
  });

  it('buildes the suites_ collection', function() {
    expect('Hello').toEqual('Hello2');
    expect('world').toEqual('world2');
  });

  // xdescribe('not able describe', function() {
  //   it('it in describe', function() {
  //     expect('Hello').toEqual('Hello');
  //     expect('world').toEqual('world');
  //   });
  // });

  it('good Hello', function() {
    expect('dd').toEqual('dd2');
  });

  // fit('focus good Hello', function() {
  //   expect('dd').toEqual('dd');
  // });

  describe('just for fun', function() {
    it('fun in fun', function() {
      expect('hellos').toEqual('hello');
    });

    xit('focus in fun', function() {
      expect('hello').toEqual('hello');
    });

    describe('ddd', function() {
      it('mmm', function() {
        expect('hellos').toEqual('hello');
      });
    });
  });
});
