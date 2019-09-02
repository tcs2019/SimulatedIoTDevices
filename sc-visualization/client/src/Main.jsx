import './Main.css';
import React from 'react';

class Main extends React.Component {
  // TODO: need to check Address & ABI

  render() {
    return (
      <div>
        <div className="ui center aligned grid">
          <div className="column">
            <h1 className="ui header">Contract Address</h1>
          </div>
        </div>
        <div className="cards-width ui cards">
          <div className="card">
            <div className="content">
              <div className="header">Transaction Hash</div>
              <div className="meta">Timestamt</div>
              <div className="description">Description</div>
            </div>
          </div>
          <div className="card">
            <div className="content">
              <div className="header">Transaction Hash</div>
              <div className="meta">Timestamt</div>
              <div className="description">Description</div>
            </div>
          </div>
          <div className="card">
            <div className="content">
              <div className="header">Transaction Hash</div>
              <div className="meta">Timestamt</div>
              <div className="description">Description</div>
            </div>
          </div>
        </div>
        <div>Contract's current state</div>
      </div>
    );
  }
}

export default Main;
