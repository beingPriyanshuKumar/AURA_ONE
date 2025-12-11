import React from 'react';
import { useNavigate } from 'react-router-dom';
import './home.css';

const Home = () => {
  const navigate = useNavigate();

  return (
    <div className="home-container">
      <h1 className="title">AURA ONE</h1>
      <p className="intro-text">
        Welcome to AURA ONE. Experience the future of hospitality with our premium
        interface and seamless user experience. 
      </p>
      <button className="login-btn" onClick={() => navigate('/login')}>
        Login
      </button>
    </div>
  );
};

export default Home;
