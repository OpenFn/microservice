// A test job to run with my microservice.
alterState(state => {
  state.newKey = true;
  state.references.push(Date.now());
  console.log('Something in the logs.');
  return state;
});

// get('https://www.isitdownrightnow.com/openfn.org.html', {}, (state) => {
//   state.newKey = true
//   return state
// });