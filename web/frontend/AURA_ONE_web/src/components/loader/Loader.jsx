import React from 'react';
import './Loader.css';

const Loader = () => {
  return (
    <div className="loader">
      <svg height="0" width="0" viewBox="0 0 64 64" className="absolute">
        <defs className="s-xJBuHA073rTt">
          <linearGradient className="s-xJBuHA073rTt" gradientUnits="userSpaceOnUse" y2="2" x2="0" y1="62" x1="0" id="b">
            <stop className="s-xJBuHA073rTt" stopColor="#3be1edff"></stop>
            <stop className="s-xJBuHA073rTt" stopColor="#3be1edff" offset="1"></stop>
          </linearGradient>
          <linearGradient className="s-xJBuHA073rTt" gradientUnits="userSpaceOnUse" y2="0" x2="0" y1="64" x1="0" id="c">
            <stop className="s-xJBuHA073rTt" stopColor="#ff5500ff"></stop>
            <stop className="s-xJBuHA073rTt" stopColor="#FFC800" offset="1"></stop>
            <animateTransform repeatCount="indefinite" keySplines=".42,0,.58,1;.42,0,.58,1;.42,0,.58,1;.42,0,.58,1;.42,0,.58,1;.42,0,.58,1;.42,0,.58,1;.42,0,.58,1" keyTimes="0; 0.125; 0.25; 0.375; 0.5; 0.625; 0.75; 0.875; 1" dur="8s" values="0 32 32;-270 32 32;-270 32 32;-540 32 32;-540 32 32;-810 32 32;-810 32 32;-1080 32 32;-1080 32 32" type="rotate" attributeName="gradientTransform"></animateTransform>
          </linearGradient>
          <linearGradient className="s-xJBuHA073rTt" gradientUnits="userSpaceOnUse" y2="2" x2="0" y1="62" x1="0" id="d">
            <stop className="s-xJBuHA073rTt" stopColor="#04ed00ff"></stop>
            <stop className="s-xJBuHA073rTt" stopColor="#04ed00ff" offset="1"></stop>
          </linearGradient>
        </defs>
      </svg>
      
      {/* A */}
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 64 64" height="64" width="64" className="inline-block">
        <path strokeLinejoin="round" strokeLinecap="round" strokeWidth="8" stroke="url(#b)" d="M 12 58 L 32 6 L 52 58 M 20 38 H 44" className="dash" pathLength="360"></path>
      </svg>

      {/* U */}
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" style={{'--rotation-duration': '0ms', '--rotation-direction': 'normal'}} viewBox="0 0 64 64" height="64" width="64" className="inline-block">
         <path strokeLinejoin="round" strokeLinecap="round" strokeWidth="8" stroke="url(#d)" d="M 4,4 h 4.6230469 v 25.919922 c -0.00276,11.916203 9.8364941,21.550422 21.7500001,21.296875 11.616666,-0.240651 21.014356,-9.63894 21.253906,-21.25586 a 2.0002,2.0002 0 0 0 0,-0.04102 V 4 H 56.25 v 25.919922 c 0,14.33873 -11.581192,25.919922 -25.919922,25.919922 a 2.0002,2.0002 0 0 0 -0.0293,0 C 15.812309,56.052941 3.998433,44.409961 4,29.919922 Z" className="dash" pathLength="360"></path>
      </svg>

      {/* R */}
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 64 64" height="64" width="64" className="inline-block">
        <path strokeLinejoin="round" strokeLinecap="round" strokeWidth="8" stroke="url(#b)" d="M 16 58 V 6 H 36 C 50 6 50 28 36 28 H 16 M 36 28 L 52 58" className="dash" pathLength="360"></path>
      </svg>

      {/* A */}
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 64 64" height="64" width="64" className="inline-block">
        <path strokeLinejoin="round" strokeLinecap="round" strokeWidth="8" stroke="url(#d)" d="M 12 58 L 32 6 L 52 58 M 20 38 H 44" className="dash" pathLength="360"></path>
      </svg>

      {/* _ */}
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 64 64" height="64" width="64" className="inline-block">
        <path strokeLinejoin="round" strokeLinecap="round" strokeWidth="8" stroke="url(#c)" d="M 12 50 H 52" className="dash" pathLength="360"></path>
      </svg>

      {/* O */}
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" style={{'--rotation-duration': '0ms', '--rotation-direction': 'normal'}} viewBox="0 0 64 64" height="64" width="64" className="inline-block">
        <path strokeLinejoin="round" strokeLinecap="round" strokeWidth="10" stroke="url(#c)" d="M 32 32 m 0 -27 a 27 27 0 1 1 0 54 a 27 27 0 1 1 0 -54" className="spin" pathLength="360"></path>
      </svg>

      {/* N */}
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 64 64" height="64" width="64" className="inline-block">
        <path strokeLinejoin="round" strokeLinecap="round" strokeWidth="8" stroke="url(#b)" d="M 14 58 V 6 L 50 58 V 6" className="dash" pathLength="360"></path>
      </svg>

      {/* E */}
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 64 64" height="64" width="64" className="inline-block">
        <path strokeLinejoin="round" strokeLinecap="round" strokeWidth="8" stroke="url(#d)" d="M 48 6 H 16 V 58 H 48 M 16 32 H 40" className="dash" pathLength="360"></path>
      </svg>
    </div>
  );
};

export default Loader;
