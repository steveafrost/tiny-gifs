export const reactions = [
  { id: 'lol', label: 'lol' },
  { id: 'nope', label: 'nope' },
  { id: 'omg', label: 'omg' },
  { id: 'brb', label: 'brb' },
  { id: 'perfect', label: 'perfect' },
  { id: 'yes', label: 'yes' },
  { id: 'yikes', label: 'yikes' },
  { id: 'tiny-clap', label: 'tiny clap' },
] as const

export type ReactionName = (typeof reactions)[number]['id']
