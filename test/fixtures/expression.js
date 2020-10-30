// A test job to run with my microservice.
alterState(state => {
  state.data.array.push(4);
  state.newKey = true;
  console.log('Something in the logs.');
  return state;
});
// get('https://www.isitdownrightnow.com/openfn.org.html', {}, (state) => {
//   state.newKey = true
//   return state
// });

// A test job to run with my microservice.
// post('localhost:4000', { body: { a: 1 } }, (state) => {
//   state.newKey = false
//   return state
// });
