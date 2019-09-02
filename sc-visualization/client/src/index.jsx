import React from 'react';
import ReactDOM from 'react-dom';
import axios from 'axios';
import config from './config.json';
import FirstStart from './FirstStart';
import Main from './Main';

class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      address: null,
      abi: null,
    };
  }

  componentDidMount() {
    // axios
    //   .get('/contract')
    //   .then(response => {
    //     console.log(response);
    //   })
    //   .catch(error => {
    //     console.log(error);
    //   });
  }

  renderContent() {
    const { address } = this.state;
    if (address === null) {
      return <FirstStart />;
    }

    return <Main contract={this.state} />;
  }

  render() {
    return <div>{this.renderContent()}</div>;
  }
}

ReactDOM.render(<App />, document.querySelector('#root'));
