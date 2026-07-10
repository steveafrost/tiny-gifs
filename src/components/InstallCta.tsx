import { useEffect, useRef, useState, type ReactNode } from 'react'

const configuredUrl = import.meta.env.VITE_INSTALL_URL?.trim()

function isSafeInstallUrl(value: string | undefined): value is string {
  if (!value) return false
  try {
    const url = new URL(value)
    return url.protocol === 'https:' || url.protocol === 'http:'
  } catch {
    return false
  }
}

type InstallCtaProps = {
  children: ReactNode
  className?: string
}

export function InstallCta({ children, className = '' }: InstallCtaProps) {
  const [isOpen, setIsOpen] = useState(false)
  const closeButtonRef = useRef<HTMLButtonElement>(null)

  useEffect(() => {
    if (!isOpen) return
    closeButtonRef.current?.focus()
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setIsOpen(false)
    }
    document.addEventListener('keydown', onKeyDown)
    return () => document.removeEventListener('keydown', onKeyDown)
  }, [isOpen])

  if (isSafeInstallUrl(configuredUrl)) {
    return <a className={className} href={configuredUrl} target="_blank" rel="noopener noreferrer">{children}</a>
  }

  return <>
    <button className={className} type="button" onClick={() => setIsOpen(true)}>{children}</button>
    {isOpen && <div className="install-sheet__backdrop" role="presentation" onMouseDown={() => setIsOpen(false)}>
      <section className="install-sheet" role="dialog" aria-modal="true" aria-labelledby="install-sheet-title" onMouseDown={(event) => event.stopPropagation()}>
        <button ref={closeButtonRef} className="install-sheet__close" type="button" onClick={() => setIsOpen(false)} aria-label="Close install information">×</button>
        <p className="install-sheet__label">#tiny-gifs</p>
        <h2 id="install-sheet-title">The beta invite is not live yet.</h2>
        <p>#tiny-gifs comes through an iPhone app. Stickers are the fastest path in Messages; the keyboard is optional for supported apps elsewhere.</p>
        <ol>
          <li>Install the app when the invite opens.</li>
          <li>Open #tiny-gifs in the Messages app drawer and tap a tiny sticker.</li>
          <li>Add the keyboard in Settings only when you want the copy-and-paste path elsewhere.</li>
        </ol>
      </section>
    </div>}
  </>
}
