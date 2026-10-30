export default function DualPath() {
  return (
    <section id="member" className="py-24 px-6 bg-cream-200 relative overflow-hidden">
      <div className="max-w-6xl mx-auto grid md:grid-cols-2 gap-8">
        <div className="bg-white rounded-3xl p-10 shadow-xl shadow-ink-900/5 relative overflow-hidden group border border-gold-400/20">
          <div className="absolute top-0 right-0 w-32 h-32 bg-gold-100 rounded-bl-full opacity-50 transition-transform group-hover:scale-110" />
          <div className="w-12 h-12 rounded-full bg-gold-50 flex items-center justify-center mb-6 text-gold-600">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 5v14M5 12h14" /></svg>
          </div>
          <h3 className="font-serif text-3xl text-ink-900 mb-3">New to IPB Hotel?</h3>
          <p className="text-ink-700/70 mb-8 leading-relaxed">Discover our rooms, venues, and experiences. Plan your first stay or event with us.</p>
          <a href="#inquiry" className="inline-flex items-center text-gold-600 font-medium hover:text-gold-700 transition-colors">Start Planning <span className="ml-2">→</span></a>
        </div>
        <div className="bg-ink-900 rounded-3xl p-10 shadow-2xl relative overflow-hidden group border border-gold-400/30">
          <div className="absolute inset-0 arch-motif opacity-20" />
          <div className="relative z-10">
            <div className="flex justify-between items-start mb-6">
              <div className="w-12 h-12 rounded-full bg-gold-400/10 flex items-center justify-center text-gold-400 border border-gold-400/30">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="5" y="2" width="14" height="20" rx="2" /><line x1="12" y1="18" x2="12" y2="18.01" /></svg>
              </div>
              <div className="w-16 h-16 bg-white rounded flex flex-wrap p-1 gap-px opacity-80">
                 {Array.from({ length: 16 }).map((_, i) => <div key={i} className={`w-3 h-3 ${Math.random() > 0.5 ? 'bg-ink-900' : 'bg-transparent'}`} />)}
              </div>
            </div>
            <h3 className="font-serif text-3xl text-cream-50 mb-3">Serenity Member</h3>
            <p className="text-cream-100/60 mb-8 leading-relaxed">Access exclusive rates, manage bookings, and unlock member privileges via the IPB Guest App.</p>
            <a href="serenity://ipb-member" className="btn-gold w-full" onClick={(e) => { if (!/iPad|iPhone|iPod|Android/.test(navigator.userAgent)) { e.preventDefault(); alert("The IPB Guest App is available on iOS and Android. Please scan the QR code or download from the store."); } }}>Open IPB Guest App</a>
          </div>
        </div>
      </div>
    </section>
  )
}