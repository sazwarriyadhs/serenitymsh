import { useCountUp } from '../hooks/useCountUp'
const stats = [
  { end: 150, suffix: '+', label: 'Hotel Rooms' },
  { end: 15, suffix: '+', label: 'Meeting Venues' },
  { end: 1000, suffix: '+', label: 'Events Hosted' },
  { end: 50, suffix: 'K+', label: 'Guests Welcomed' },
]
export default function Numbers() {
  return (
    <section className="bg-ink-800 py-24 border-y border-gold-400/10">
      <div className="max-w-7xl mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-12 text-center">
        {stats.map((stat, i) => <StatItem key={i} {...stat} />)}
      </div>
    </section>
  )
}
function StatItem({ end, suffix, label }) {
  const { count, ref } = useCountUp(end)
  return (
    <div ref={ref}>
      <div className="font-serif text-5xl md:text-6xl text-gold-gradient mb-2">{count}{suffix}</div>
      <div className="text-sm text-cream-100/60 tracking-wider uppercase">{label}</div>
    </div>
  )
}