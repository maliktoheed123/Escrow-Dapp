import React from 'react';
import './App.css';

function App() {
  return (
    <div className="app">
      <header className="navbar">
        <div className="logo">CSCrow</div>
        <div className="nav-links">
          <a href="#">Home</a>
          <a href="#">Sent</a>
          <a href="#">Received</a>
          <a href="#">Dispute</a>
          <a href="#">Validate</a>
          <a href="#">Claim</a>
        </div>
        <button className="wallet-button">0xAbc...123</button>
      </header>

      <section className="main-content">
        <h1>Make Scam Free Crypto Payments</h1>
        <p className="subtitle">Decentralized 'fiverr' that holds your crypto until service is received to protect you from scams</p>

        <div className="form-section">
          <form className="form-card">
            <input type="text" placeholder="Title" />
            <input type="text" placeholder="Receiver" />
            <select>
              <option value="">Select Token</option>
              <option value="ETH">ETH</option>
              <option value="USDT">USDT</option>
            </select>
            <div className="row">
              <input type="text" placeholder="Total in Tokens" />
              <input type="text" placeholder="Total in USD" />
            </div>
            <textarea placeholder="Details"></textarea>
            <button type="submit" className="submit-btn">Create Contract</button>
            <p className="fee-note">2% service fee</p>
          </form>
        </div>

        <div className="cta-buttons">
          <button className="cta">Send</button>
          <button className="cta">Learn</button>
          <button className="cta">Earn</button>
        </div>

        <section className="how-section">
          <h2><span className="highlight">HOW</span> CSCROW WORKS?</h2>
          <div className="steps">
            <div className="step">1</div>
            <div className="step">2</div>
            <div className="step">3</div>
            <div className="step">4</div>
          </div>
        </section>
      </section>
    </div>
  );
}

export default App;
