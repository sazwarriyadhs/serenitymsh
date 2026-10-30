export default function Footer() {
  return (
    <footer className="bg-ink-900 pt-20 pb-10 border-t border-gold-400/20 text-cream-100/60">
      <div className="max-w-7xl mx-auto px-6 grid md:grid-cols-3 gap-12 mb-16">
        {/* Kolom Kiri: Logo IPB & Powered by Serenity */}
        <div>
          <img src="/iicc-logo-1.png" alt="IPB Convention Center" className="h-12 w-auto object-contain mb-4" />
          <p className="text-sm leading-relaxed mb-6">
            IPB International Convention Center & IPB Convention Hotel.
          </p>
          <div className="flex items-center gap-3 mt-6">
  <span className="text-[10px] text-cream-100/40 uppercase tracking-widest">Powered by</span>
  <img
    src="/serenity_logo.png"
    alt="Serenity HMS"
    className="h-10 w-auto object-contain opacity-80 hover:opacity-100 transition-opacity"
    style={{ filter: 'drop-shadow(0 0 8px rgba(212, 175, 55, 0.4))' }}
  />
</div>
        </div>

        {/* Kolom Tengah: Links */}
        <div className="grid grid-cols-2 gap-8 text-sm">
          <div>
            <h4 className="text-gold-300 uppercase tracking-widest mb-4 text-xs">Explore</h4>
            <ul className="space-y-2">
              <li><a href="#" className="hover:text-gold-300">Rooms & Suites</a></li>
              <li><a href="#" className="hover:text-gold-300">Dining</a></li>
              <li><a href="#" className="hover:text-gold-300">Events</a></li>
            </ul>
          </div>
          <div>
            <h4 className="text-gold-300 uppercase tracking-widest mb-4 text-xs">Connect</h4>
            <ul className="space-y-2">
              <li><a href="#" className="hover:text-gold-300">Contact Us</a></li>
              <li><a href="#" className="hover:text-gold-300">Instagram</a></li>
              <li><a href="#" className="hover:text-gold-300">LinkedIn</a></li>
            </ul>
          </div>
        </div>

        {/* Kolom Kanan: QR Code / App */}
        <div className="bg-ink-800 rounded-2xl p-6 border border-gold-400/10 flex items-center gap-4">
           <div className="w-20 h-20 bg-white rounded flex flex-wrap p-1 gap-px shrink-0">
              {Array.from({ length: 36 }).map((_, i) => (
                 <div key={i} className={`w-2 h-2 ${Math.random() > 0.5 ? 'bg-ink-900' : 'bg-transparent'}`} />
              ))}
           </div>
           <div>
             <h4 className="text-cream-50 text-sm font-medium mb-1">Get the App</h4>
             <p className="text-xs text-cream-100/50 mb-3">Scan to manage bookings.</p>
             <a href="#" className="text-gold-400 text-xs font-semibold hover:text-gold-300">Download →</a>
           </div>
        </div>
      </div>

      {/* Bottom Bar */}
      <div className="max-w-7xl mx-auto px-6 pt-8 border-t border-white/5 flex flex-col md:flex-row items-center justify-between text-xs">
        <p>© 2026 IPB Convention Hotel. All rights reserved.</p>
        <p className="mt-2 md:mt-0">Powered by <span className="text-gold-400">Serenity HMS</span> v0.0.1</p>
      </div>
    </footer>
  )
}
