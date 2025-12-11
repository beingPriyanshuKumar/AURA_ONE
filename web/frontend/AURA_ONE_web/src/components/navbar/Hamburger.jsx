import React from 'react'

export default function Hamburger({ open, onClick }) {
  return (
    <button className="hamburger" aria-label="Toggle navigation" onClick={onClick}>
      <span className={open ? "bar open" : "bar"}></span>
      <span className={open ? "bar open" : "bar"}></span>
      <span className={open ? "bar open" : "bar"}></span>
    </button>
  )
}
