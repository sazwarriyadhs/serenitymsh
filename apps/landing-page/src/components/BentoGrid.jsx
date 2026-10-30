export default function BentoGrid() {
  return (
    <section id="stay" className="py-24 px-6 max-w-7xl mx-auto">
      <div className="text-center mb-16">
        <h2 className="font-serif text-4xl md:text-5xl text-ink-900">A Sanctuary for Stay & Convention</h2>
        <p className="mt-4 text-ink-700/70">Refined spaces designed for rest, connection, and grand gatherings.</p>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 auto-rows-[250px]">
        {/* Card Besar Kiri - Hotel */}
        <div className="md:col-span-2 md:row-span-2 rounded-3xl overflow-hidden relative group">
          <img src="/hero-lobby.jpg" alt="IPB Convention Hotel" className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" />
          <div className="absolute inset-0 bg-gradient-to-t from-ink-900/90 via-ink-900/20 to-transparent z-10" />
          <div className="absolute bottom-8 left-8 z-20">
            <h3 className="font-serif text-3xl text-cream-50">IPB Convention Hotel</h3>
            <p className="text-gold-300 text-sm mt-2">Unwind in elegantly appointed rooms.</p>
          </div>
        </div>
        
        {/* Card Kanan Atas - Conference */}
        <div className="rounded-3xl overflow-hidden relative group">
          <img src="/confrence.jpg" alt="Conference Hall" className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" />
          <div className="absolute inset-0 bg-gradient-to-t from-ink-900/90 to-transparent z-10" />
          <div className="absolute bottom-6 left-6 z-20">
            <h3 className="font-serif text-2xl text-cream-50">Conference Halls</h3>
            <p className="text-gold-300/80 text-xs mt-1">Where great ideas convene.</p>
          </div>
        </div>
        
        {/* Card Kanan Bawah - Showcase/Exhibition */}
        <div className="rounded-3xl overflow-hidden relative group">
          <img src="/showcase.jpg" alt="Exhibition Space" className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" />
          <div className="absolute inset-0 bg-gradient-to-t from-ink-900/90 to-transparent z-10" />
          <div className="absolute bottom-6 left-6 z-20">
            <h3 className="font-serif text-2xl text-cream-50">Exhibition Space</h3>
            <p className="text-gold-300/80 text-xs mt-1">Showcase your best work.</p>
          </div>
        </div>
      </div>
    </section>
  )
}