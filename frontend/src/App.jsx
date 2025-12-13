import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [message, setMessage] = useState('Cargando...')
  const [dbStatus, setDbStatus] = useState(null)

  useEffect(() => {
    // Fetch root message
    fetch('/api/')
      .then(res => res.json())
      .then(data => setMessage(data.estado))
      .catch(err => setMessage('Error conectando al backend: ' + err))

    // Fetch DB status
    fetch('/api/db-test')
      .then(res => res.json())
      .then(data => setDbStatus(data))
      .catch(err => console.error(err))
  }, [])

  return (
    <>
      <h1>FastAPI + React en Azure</h1>
      <div className="card">
        <h2>Backend:</h2>
        <p>{message}</p>
      </div>

      {dbStatus && (
        <div className="card">
          <h2>Base de Datos:</h2>
          <p>Estado: {dbStatus.estado_db}</p>
          {dbStatus.version && <p>Versión: {dbStatus.version}</p>}
        </div>
      )}
    </>
  )
}

export default App
