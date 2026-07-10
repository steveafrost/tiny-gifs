import type { ReactNode } from 'react'
import type { ReactionName } from '../data/reactions'

export type { ReactionName } from '../data/reactions'

type ReactionCharacterProps = {
  kind?: ReactionName
  className?: string
  compact?: boolean
  decorative?: boolean
}

const faces: Record<ReactionName, ReactNode> = {
  lol: <><path d="M37 44 48 35 59 44" fill="none" stroke="currentColor" strokeWidth="5" /><path d="M77 44 88 35 99 44" fill="none" stroke="currentColor" strokeWidth="5" /><path d="M45 58h47l-7 24H52z" fill="currentColor" /></>,
  nope: <><circle cx="52" cy="52" r="5" fill="currentColor" /><circle cx="91" cy="52" r="5" fill="currentColor" /><path d="m50 78 44-8 2 10-44 8z" fill="currentColor" /></>,
  omg: <><circle cx="54" cy="48" r="6" fill="currentColor" /><circle cx="91" cy="48" r="6" fill="currentColor" /><circle cx="73" cy="75" r="15" fill="currentColor" /></>,
  brb: <><circle cx="52" cy="58" r="5" fill="currentColor" /><circle cx="91" cy="58" r="5" fill="currentColor" /><path d="M51 79h42v10H51z" fill="currentColor" /></>,
  perfect: <><circle cx="52" cy="54" r="5" fill="currentColor" /><circle cx="91" cy="54" r="5" fill="currentColor" /><path d="M50 72c12 13 30 13 43 0" fill="none" stroke="currentColor" strokeWidth="7" /></>,
  yes: <><circle cx="73" cy="57" r="6" fill="currentColor" /><path d="m49 74 17 16 30-36" fill="none" stroke="currentColor" strokeWidth="7" strokeLinecap="round" strokeLinejoin="round" /></>,
  yikes: <><circle cx="54" cy="52" r="6" fill="currentColor" /><circle cx="91" cy="52" r="6" fill="currentColor" /><path d="M51 87q22-24 44 0" fill="none" stroke="currentColor" strokeWidth="7" strokeLinecap="round" /></>,
  'tiny-clap': <><circle cx="52" cy="57" r="5" fill="currentColor" /><circle cx="91" cy="57" r="5" fill="currentColor" /><path d="M52 77h43v9H52z" fill="currentColor" /></>,
}

export function ReactionCharacter({ kind = 'omg', className = '', compact = false, decorative = false }: ReactionCharacterProps) {
  return (
    <svg
      className={`reaction-character reaction-character--${kind} ${compact ? 'reaction-character--compact' : ''} ${className}`}
      viewBox="0 0 145 120"
      role={decorative ? undefined : 'img'}
      aria-label={decorative ? undefined : `${kind} reaction`}
      aria-hidden={decorative || undefined}
    >
      {kind === 'perfect' || kind === 'yikes' ? <path d={kind === 'perfect' ? 'm72 11 13 29 31 3-23 21 6 32-27-16-27 16 6-32-23-21 31-3z' : 'm72 8 11 27 26-15-2 30 29 2-22 19 20 20-29 2 2 29-27-15-13 25-11-27-26 15 2-30-29-2 22-19-20-20 29-2-2-29 27 15z'} fill={kind === 'perfect' ? '#71C9FF' : '#FF6B57'} /> : kind === 'yes' ? <path d="M72 13 116 100H28z" fill="#C8FF3D" stroke="#111" strokeWidth="4" /> : kind === 'tiny-clap' ? <path d="M51 103 29 62c-6-10 6-18 13-8l12 17-4-38c-1-10 13-12 15-2l5 25 3-34c1-10 15-9 15 1l-2 35 13-22c5-9 18-2 12 7L94 81c-8 14-20 21-43 22z" fill="#C8FF3D" stroke="#111" strokeWidth="4" /> : <path className="reaction-character__body" d={kind === 'nope' ? 'M35 24h76l-2 76H33z' : kind === 'brb' ? 'M33 25h78l-3 73H31z' : 'M72 16a42 42 0 1 1 0 84 42 42 0 0 1 0-84Z'} fill={kind === 'lol' || kind === 'brb' ? '#C8FF3D' : kind === 'nope' ? '#71C9FF' : '#FF6B57'} />}
      <g className="reaction-character__face">{faces[kind]}</g>
      {kind === 'lol' && <circle cx="120" cy="91" r="13" fill="#71C9FF" />}
      {kind === 'nope' && <path d="m111 83 11-11 8 8 11-11 8 8-11 11 11 11-8 8-11-11-11 11-8-8 11-11-11-11z" fill="#FF6B57" />}
      {kind === 'omg' && <path d="m18 22 6 13 14 1-11 10 3 15-12-8-12 8 3-15L-2 36l14-1z" fill="#C8FF3D" />}
      {kind === 'brb' && <circle cx="120" cy="91" r="13" fill="#71C9FF" />}
      {kind === 'perfect' && <circle cx="121" cy="25" r="9" fill="#FF6B57" />}
      {kind === 'yes' && <path d="m59 70 10 10 19-24" fill="none" stroke="#111" strokeWidth="5" strokeLinecap="round" strokeLinejoin="round" />}
      {kind === 'yikes' && <path d="M117 20 125 10M123 31l12-4" fill="none" stroke="#111" strokeWidth="3" />}
      {kind === 'tiny-clap' && <><path d="m25 28-9-8M20 39l-12-4M116 30l8-12M122 41l13-4" fill="none" stroke="#111" strokeWidth="3" /><path d="M54 75q20 12 39-5" fill="none" stroke="#111" strokeWidth="5" strokeLinecap="round" /></>}
      <g className="reaction-character__rays" stroke="#111" strokeWidth="3" strokeLinecap="square">
        <path d="M21 25 12 17" /><path d="M16 36 6 31" /><path d="M115 20 122 9" /><path d="M122 30 135 25" />
      </g>
    </svg>
  )
}
