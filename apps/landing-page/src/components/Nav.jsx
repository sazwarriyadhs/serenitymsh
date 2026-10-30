import { useEffect, useState } from 'react'
export default function Nav() {
  const [scrolled, setScrolled] = useState(false)
  const [progress, setProgress] = useState(0)
  useEffect(() => {
    const onScroll = () => {
      setScrolled(window.scrollY > 40)
      const h = document.documentElement.scrollHeight - window.innerHeight
      setProgress(h > 0 ? (window.scrollY / h) * 100 : 0)
    }
    window.addEventListener('scroll', onScroll, { passive: true })
    onScroll()
    return () => window.removeEventListener('scroll', onScroll)
  }, [])
  return (
    <>
      <div className="fixed top-0 left-0 right-0 h-[2px] z-[60] bg-transparent">
        <div className="h-full transition-[width] duration-150" style={{ width: `${progress}%`, background: 'linear-gradient(90deg, #B8860B, #D4AF37, #F5E9C7)' }} />
      </div>
      <nav className={`fixed top-[2px] left-0 right-0 z-50 transition-all duration-500 ${scrolled ? 'glass-nav py-3' : 'py-6 bg-transparent'}`}>
        <div className="max-w-7xl mx-auto px-6 flex items-center justify-between">
          <a href="#top" className="flex items-center">
            <img src="/iicc-logo-1.png" alt="IPB Convention Center" className="h-12 w-auto object-contain" />
          </a>
          <div className="hidden md:flex items-center gap-8 text-sm">
            {['Stay', 'Experience', 'Events', 'Location'].map((item) => (
              <a key={item} href={`#${item.toLowerCase()}`} className="text-white/80 hover:text-gold-300 transition-colors duration-300">{item}</a>
            ))}
          </div>
          <div className="flex items-center gap-3">
            <a href="#member" className="hidden sm:inline-flex text-sm text-white/80 hover:text-gold-300 transition-colors">Member Login</a>
            <a href="#inquiry" className="btn-gold !py-2.5 !px-5 text-sm">Book Now</a>
          </div>
        </div>
      </nav>
    </>
  )
}
function LogoMark() {
  return (
    <svg width="36" height="42" viewBox="0 0 36 42" fill="none">
      <defs><linearGradient id="goldGrad" x1="0" y1="0" x2="1" y2="1"><stop offset="0%" stopColor="#F5E9C7" /><stop offset="50%" stopColor="#D4AF37" /><stop offset="100%" stopColor="#B8860B" /></linearGradient></defs>
      <path d="M4 40 V18 C4 8 12 2 18 2 C24 2 32 8 32 18 V40" stroke="url(#goldGrad)" strokeWidth="1.8" fill="none" />
      <rect x="13" y="18" width="10" height="22" stroke="url(#goldGrad)" strokeWidth="1.4" fill="none" />
      <rect x="16" y="22" width="4" height="18" fill="url(#goldGrad)" opacity="0.5" />
      <path d="M18 0 L20 4 L18 8 L16 4 Z" fill="url(#goldGrad)" />
      <path d="M6 36 Q12 32 18 36 T30 36" stroke="url(#goldGrad)" strokeWidth="1.4" fill="none" />
    </svg>
  )
}