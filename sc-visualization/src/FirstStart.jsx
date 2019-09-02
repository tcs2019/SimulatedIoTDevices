import React from 'react';
import axios from 'axios';

class FirstStart extends React.Component {
  // eslint-disable-next-line react/state-in-constructor
  state = {
    address: '',
    abiFile: null,
  };

  onAddressChange = event => {
    this.setState({
      address: event.target.value,
    });
  };

  onABIChange = event => {
    this.setState({
      abiFile: event.target.files[0],
      loaded: 0,
    });
  };

  onClickHandler = () => {
    // eslint-disable-next-line no-undef
    const data = new FormData();
    data.append('file', this.state.abiFile);
    axios.post('/upload', data).then(res => {
      console.log(res.statusText);
    });
  };

  render() {
    return (
      <div className="ui middle aligned center aligned grid">
        <div className="eight wide column">
          <h1 className="ui header">Welcome</h1>
          <form className="ui form">
            <div className="field">
              <label htmlFor="address" align="left">
                Address
              </label>
              <input type="text" name="address" placeholder="Contract Address" onChange={this.onAddressChange} />
            </div>
            <div className="field">
              <label htmlFor="abi" align="left">
                ABI
              </label>
              <input type="file" name="abi" onChange={this.onABIChange} />
            </div>
            <button className="ui button" onClick={this.onClickHandler}>
              Start
            </button>
          </form>
        </div>
      </div>
    );
  }
}

export default FirstStart;
