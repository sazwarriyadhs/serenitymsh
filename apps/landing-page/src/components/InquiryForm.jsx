import { useState } from 'react'
import { submitInquiry } from '../lib/api'

export default function InquiryForm() {
  const [status, setStatus] = useState('idle') // idle | loading | success | error
  const [message, setMessage] = useState('')
  
  const [formData, setFormData] = useState({ 
    name: '', 
    email: '', 
    type: 'Room Reservation', 
    message: '' 
  })

  const handleSubmit = async (e) => {
    e.preventDefault()
    setStatus('loading')
    
    // Format data agar sesuai dengan struct yang diharapkan backend Go (nanti)
    const payload = {
      guest_name: formData.name,
      email: formData.email,
      inquiry_type: formData.type,
      notes: formData.message
    }

    const res = await submitInquiry(payload)
    
    if (res.status === 'error') {
      setStatus('error')
      setMessage(res.message)
    } else {
      setStatus('success')
    }
    
    // Reset status setelah 5 detik
    setTimeout(() => {
      if (status !== 'loading') setStatus('idle')
    }, 5000)
  }

  return (
    <section id="inquiry" className="py-24 px-6 bg-cream-100 relative">
      <div className="max-w-3xl mx-auto bg-white rounded-3xl p-8 md:p-12 shadow-2xl shadow-ink-900/5 border border-gold-400/20">
        <div className="text-center mb-10">
          <h2 className="font-serif text-3xl text-ink-900">Plan Your Experience</h2>
          <p className="text-ink-700/60 mt-2">Leave your details and our team will be in touch.</p>
        </div>
        
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid md:grid-cols-2 gap-6">
            <div>
              <label className="block text-xs uppercase tracking-widest text-ink-700/60 mb-2">Name</label>
              <input required type="text" className="w-full bg-transparent border-b border-gold-400/30 focus:border-gold-500 py-2 outline-none text-ink-900" onChange={e => setFormData({...formData, name: e.target.value})} />
            </div>
            <div>
              <label className="block text-xs uppercase tracking-widest text-ink-700/60 mb-2">Email</label>
              <input required type="email" className="w-full bg-transparent border-b border-gold-400/30 focus:border-gold-500 py-2 outline-none text-ink-900" onChange={e => setFormData({...formData, email: e.target.value})} />
            </div>
          </div>
          
          <div>
            <label className="block text-xs uppercase tracking-widest text-ink-700/60 mb-2">Interested In</label>
            <select className="w-full bg-transparent border-b border-gold-400/30 focus:border-gold-500 py-2 outline-none text-ink-900" onChange={e => setFormData({...formData, type: e.target.value})}>
              <option>Room Reservation</option>
              <option>Event Space</option>
              <option>Wedding Package</option>
              <option>MICE / Convention</option>
            </select>
          </div>
          
          <div>
            <label className="block text-xs uppercase tracking-widest text-ink-700/60 mb-2">Message</label>
            <textarea required rows="3" className="w-full bg-transparent border-b border-gold-400/30 focus:border-gold-500 py-2 outline-none resize-none text-ink-900" onChange={e => setFormData({...formData, message: e.target.value})} />
          </div>
          
          <button disabled={status === 'loading'} type="submit" className="btn-gold w-full mt-4 disabled:opacity-70">
            {status === 'loading' ? 'Sending...' : 'Send Inquiry'}
          </button>
          
          {status === 'success' && (
            <p className="text-green-600 text-center text-sm mt-4 font-medium bg-green-50 p-3 rounded">
              Thank you. Your inquiry has been received. We will contact you shortly.
            </p>
          )}
          
          {status === 'error' && (
            <p className="text-red-600 text-center text-xs mt-4 bg-red-50 p-2 rounded">
              ⚠️ {message}
            </p>
          )}
        </form>
      </div>
    </section>
  )
}