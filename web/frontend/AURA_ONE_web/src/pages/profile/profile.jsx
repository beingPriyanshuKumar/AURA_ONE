import React from 'react'
import Sidebar from '../../components/SideBar/sidebar'


const Profile = () => {
  return (
    <div className="profile-layout">
        <div className="sidebar" style={{ width: '100%', maxWidth: '300px' }}>
            <Sidebar />
        </div>
        <div className="profile-main-card">
           <h1>Welcome to your Profile</h1>
        </div>
    </div>
  )
}

export default Profile
