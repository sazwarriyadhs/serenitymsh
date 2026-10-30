import { useEffect, useState } from 'react'
import { motion } from 'framer-motion'
export default function Hero() {
  const [offset, setOffset] = useState(0)
  useEffect(() => {
    const onScroll = () => setOffset(window.scrollY)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])
  return (
    <section id="top" className="relative min-h-screen flex items-center justify-center overflow-hidden bg-ink-900">
      <div className="absolute inset-0" style={{ transform: `translateY(${offset * 0.35}px)` }}>
        <img 
          src="/hero-lobby.jpg" 
          alt="IPB Hotel Lobby" 
          className="w-full h-full object-cover object-center"
          onError={(e) => { e.target.style.display = 'none'; e.target.parentElement.style.background = 'linear-gradient(135deg, #0A0E1A 0%, #1A2033 100%)'; }}
        />
      </div>
      <div className="absolute inset-0 bg-gradient-to-b from-ink-900/80 via-ink-900/40 to-ink-900/90" />
      <div className="absolute inset-0" style={{ background: 'radial-gradient(ellipse 80% 60% at 50% 110%, rgba(212,175,55,0.15), transparent 60%)' }} />
      <div className="relative z-10 max-w-6xl mx-auto px-6 text-center pt-32 pb-24">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 1, delay: 0.2 }} className="flex items-center justify-center gap-4 mb-8">
          <div className="h-px w-12 bg-gold-400/60" />
          <span className="text-[11px] tracking-[0.4em] text-gold-300 uppercase drop-shadow-md">IPB International Convention Center</span>
          <div className="h-px w-12 bg-gold-400/60" />
        </motion.div>
        <motion.h1 initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 1.1, delay: 0.4 }} className="font-serif text-5xl md:text-7xl lg:text-8xl leading-[1.05] text-cream-50 drop-shadow-lg">
          Where serenity<br /><span className="text-gold-gradient italic drop-shadow-sm">becomes your stay.</span>
        </motion.h1>
        <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 1, delay: 0.7 }} className="mt-8 max-w-xl mx-auto text-white/90 text-base md:text-lg leading-relaxed drop-shadow-md">
          Experience refined hospitality and world-class MICE facilities at IPB Convention Hotel and IPB International Convention Center.
        </motion.p>
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 1, delay: 1 }} className="mt-12 flex flex-col sm:flex-row items-center justify-center gap-4">
          <a href="#inquiry" className="btn-gold w-full sm:w-auto">I am a New Guest <span className="text-lg">→</span></a>
          <a href="#member" className="btn-outline w-full sm:w-auto">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="5" y="2" width="14" height="20" rx="2" /><line x1="12" y1="18" x2="12" y2="18.01" /></svg>
            I am a Member. Open App
          </a>
        </motion.div>
      </div>
      <motion.div animate={{ y: [0, 8, 0] }} transition={{ duration: 2, repeat: Infinity }} className="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2">
        <span className="text-[10px] tracking-[0.3em] text-gold-300/80 uppercase">Scroll</span>
        <div className="w-px h-10 bg-gradient-to-b from-gold-400/80 to-transparent" />
      </motion.div>
    </section>
  )
}