import React, { useState } from 'react'
import { useNavigate } from "react-router-dom";
const Login = () => {

  const [year, setYear] = useState('')

  const navigate = useNavigate()
  const handleSubmit = (e)=>{
    e.preventDefault()
     navigate('/profile');
  }


  // This is just for demo purpose..Please replace this shitty ai-code with your creativity. Best Wishes from @Mytricks-Code
  return (
    <div className="md:h-auto my-18 mx-3 md:my-8 md:mx-0 flex items-center justify-center">
      <div className="w-full max-w-md bg-white/80 border border-slate-200 rounded-2xl shadow-xl px-8 py-10">
        {/* Header */}
        <div className="mb-8 text-center">
          <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
            Welcome back 👋
          </h1>
          <p className="mt-2 text-sm text-slate-600">
            Login with your credentials
          </p>
        </div>

        {/* Form */}
        <form className="space-y-5" onSubmit={(e)=>handleSubmit(e)}>
          {/* Email */}
          <div className="space-y-1">
            <label
              htmlFor="email"
              className="block text-sm font-medium text-slate-900"
            >
              Email address
            </label>
            <input
              id="email"
              type="email"
              required
              className="w-full mt-1 px-3 py-2 rounded-xl bg-slate-50 border border-slate-300 text-slate-900 text-sm placeholder:text-slate-400 outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition"
              placeholder="you@example.com"
            />
          </div>

          {/* Password */}
          <div className="space-y-1">
            <label
              htmlFor="password"
              className="block text-sm font-medium text-slate-900"
            >
              Password
            </label>
            <input
              id="password"
              type="password"
              required
              className="w-full mt-1 px-3 py-2 rounded-xl bg-slate-50 border border-slate-300 text-slate-900 text-sm placeholder:text-slate-400 outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition"
              placeholder="••••••••"
            />
          </div>



          {/* Submit */}
          <button
            type="submit"
            className="w-full mt-2 py-2.5 rounded-xl bg-indigo-500 hover:bg-indigo-400 active:bg-indigo-600  text-sm font-medium shadow-lg shadow-indigo-500/30 transition-transform transform hover:-translate-y-0.5"
          >
            Login
          </button>
        </form>

        {/* Extra */}
        <p className="mt-6 text-[11px] text-center text-slate-500">
          By continuing, you agree to our{" "}
          <span className="text-slate-900 underline underline-offset-2 cursor-pointer">
            Terms
          </span>{" "}
          &{" "}
          <span className="text-slate-900 underline underline-offset-2 cursor-pointer">
            Privacy Policy
          </span>
          .
        </p>
      </div>
    </div>
  )
}

export default Login