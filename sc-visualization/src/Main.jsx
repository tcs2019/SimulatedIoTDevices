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
              <div className="header">Elliot Fu</div>
              <div className="meta">Friend</div>
              <div className="description">Elliot Fu is a.</div>
            </div>
          </div>
          <div className="card">
            <div className="content">
              <div className="header">Veronika Ossi</div>
              <div className="meta">Friend</div>
              <div className="description">
                Veronika Ossi is a set designer living in New York who enjoys kittens, music, and partying.
              </div>
            </div>
          </div>
          <div className="card">
            <div className="content">
              <div className="header">Jenny Hess</div>
              <div className="meta">Friend</div>
              <div className="description">Jenny is a student studying Media Management at the New School</div>
            </div>
          </div>
        </div>
        <div>Contract's current state</div>
      </div>
    );
  }
}

export default Main;
