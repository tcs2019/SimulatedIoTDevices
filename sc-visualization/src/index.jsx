import React from 'react';
import ReactDOM from 'react-dom';
import config from './config.json';
import FirstStart from './FirstStart';
import Main from './Main';

class App extends React.Component {
  // eslint-disable-next-line react/state-in-constructor
  state = {
    address: config.CONTRACT_ADDRESS,
    abi: config.CONTARCT_ABI,
  };

  componentDidMount() {
    // TODO: find address from server
  }

  renderContent() {
    if (this.state.address === '') {
      return <FirstStart />;
    }

    return <Main contract={this.state} />;
  }

  render() {
    return <div>{this.renderContent()}</div>;
  }
}

ReactDOM.render(<App />, document.querySelector('#root'));
