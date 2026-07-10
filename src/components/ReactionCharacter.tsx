import type { ReactNode } from 'react'

export type ReactionName = 'lol' | 'nope' | 'omg' | 'brb' | 'perfect'

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
      {kind === 'perfect' ? <path d="m72 11 13 29 31 3-23 21 6 32-27-16-27 16 6-32-23-21 31-3z" fill="#71C9FF" /> : <path className="reaction-character__body" d={kind === 'nope' ? 'M35 24h76l-2 76H33z' : kind === 'brb' ? 'M33 25h78l-3 73H31z' : 'M72 16a42 42 0 1 1 0 84 42 42 0 0 1 0-84Z'} fill={kind === 'lol' || kind === 'brb' ? '#C8FF3D' : kind === 'nope' ? '#71C9FF' : '#FF6B57'} />}
      <g className="reaction-character__face">{faces[kind]}</g>
      {kind === 'lol' && <circle cx="120" cy="91" r="13" fill="#71C9FF" />}
      {kind === 'nope' && <path d="m111 83 11-11 8 8 11-11 8 8-11 11 11 11-8 8-11-11-11 11-8-8 11-11-11-11z" fill="#FF6B57" />}
      {kind === 'omg' && <path d="m18 22 6 13 14 1-11 10 3 15-12-8-12 8 3-15L-2 36l14-1z" fill="#C8FF3D" />}
      {kind === 'brb' && <circle cx="120" cy="91" r="13" fill="#71C9FF" />}
      {kind === 'perfect' && <circle cx="121" cy="25" r="9" fill="#FF6B57" />}
      <g className="reaction-character__rays" stroke="#111" strokeWidth="3" strokeLinecap="square">
        <path d="M21 25 12 17" /><path d="M16 36 6 31" /><path d="M115 20 122 9" /><path d="M122 30 135 25" />
      </g>
    </svg>
  )
}
