const events = [
  { 
    title: 'Conferences & Seminars', 
    desc: 'Scale & sophistication', 
    image: '/confrence.jpg' 
  },
  { 
    title: 'Weddings & Galas', 
    desc: 'Unforgettable celebrations', 
    image: '/wedding.jpg' 
  },
  { 
    title: 'Exhibitions & Showcase', 
    desc: 'Showcase & connect', 
    image: '/showcase.jpg' 
  },
  { 
    title: 'Corporate Meetings', 
    desc: 'Productive & refined', 
    image: '/hero-lobby.jpg' 
  },
]

export default function EventTypes() {
  return (
    <section id="events" className="py-24 overflow-hidden bg-cream-100">
      <div className="max-w-7xl mx-auto px-6 mb-12">
        <h2 className="font-serif text-4xl md:text-5xl text-ink-900">Host Your Moments</h2>
        <p className="mt-4 text-ink-700/70">From grand academic conventions to intimate private galas.</p>
      </div>
      <div className="flex gap-6 px-6 overflow-x-auto no-scrollbar snap-x pb-8 max-w-7xl mx-auto">
        {events.map((ev, i) => (
          <div key={i} className="min-w-[300px] md:min-w-[400px] h-[350px] rounded-3xl overflow-hidden snap-start shadow-xl relative group cursor-pointer">
            <img src={ev.image} alt={ev.title} className="absolute inset-0 w-full h-full object-cover transition-transform duration-700 group-hover:scale-110" />
            <div className="absolute inset-0 bg-gradient-to-t from-ink-900/90 via-ink-900/40 to-transparent" />
            <div className="absolute bottom-8 left-8 z-10">
              <h3 className="font-serif text-3xl text-cream-50 mb-1">{ev.title}</h3>
              <p className="text-gold-300 text-sm font-medium">{ev.desc}</p>
            </div>
          </div>
        ))}
      </div>
    </section>
  )
}