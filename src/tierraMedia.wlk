object baculo {
    var property poderBase = 250

    method poderOtorgado(unGuerrero) {
        var poder = poderBase
        if (unGuerrero.tienePocaVida()) {
            poder = poderBase * 2
        }
        return poder.min(400)
    }
}

object espada {
    var property magia = magiaElfica

    method poderOtorgado(unGuerrero) = magia.poderOtorgado(unGuerrero) * 10
}

object magiaElfica {
    method poderOtorgado(unGuerrero) = 25
}

object magiaEnana {
    method poderOtorgado(unGuerrero) = unGuerrero.vida() / 2
}

object flechaAluminio {
    var property poder = 50 
    method poderOtorgado(unGuerrero) = poder
}

object flechaHierro {
    var property estaOxidada = false 

    method poderOtorgado(unGuerrero) {
        if (estaOxidada) {
            return 35 
        } else {
            return 70
        }
    }
    
    method oxidar() { estaOxidada = true }
}

object flechaBronce {
    var property fechaLustrado = new Date(day = 1, month = 1, year = 2024)
    var property fechaUso = new Date() 

    method poderOtorgado(unGuerrero) {
        var diasPasados = fechaUso - fechaLustrado
        return 0.max(100 - diasPasados)
    }
}

object cajaFlechas {
    var property flechas = [flechaAluminio, flechaHierro, flechaBronce]

    method poderOtorgado(unGuerrero) {
        var flechasUtiles = flechas.filter({ flecha => flecha.poderOtorgado(unGuerrero) > 50 })
        return flechasUtiles.sum({ flecha => flecha.poderOtorgado(unGuerrero) }) / flechasUtiles.size().max(1)
    }
}

object gandalf {
    var property vidaActual = 100
    var property armas = [baculo, espada, cajaFlechas]

    method vida() = vidaActual
    method tienePocaVida() = vidaActual < 10

    method poder() {
        var poderArmas = armas.sum({arma => arma.poderOtorgado(self)})
        var multiplicador = if (self.tienePocaVida()) 200 else 15
        
        return (vidaActual * multiplicador) + (poderArmas * 2)
    }

    method cantidadDeArmas() = armas.size()
    method estaArmado() = armas.size() > 0
    method perderVida(cantidad) { vidaActual = 0.max(vidaActual - cantidad) }
    method ganarVida(cantidad) { vidaActual += cantidad }
}

object tomBombadil {
    var property vidaActual = 100

    method vida() = vidaActual
    method tienePocaVida() = false
    method poder() = 2000
    method cantidadDeArmas() = 100
    method estaArmado() = true
    
    method perderVida(cantidad) { }
    method ganarVida(cantidad) { vidaActual += cantidad }
}

object lebennin {
    var property cantidadGuardias = 3

    method puedePasar(unGuerrero) {
        var poderMinimoParaPasar = if (cantidadGuardias > 3) 1500 else 1000
        return unGuerrero.poder() > poderMinimoParaPasar
    }
    
    method consecuencia(unGuerrero) { }
}

object minasTirith {
    method puedePasar(unGuerrero) = unGuerrero.estaArmado()

    method consecuencia(unGuerrero) {
        if (self.puedePasar(unGuerrero)) {
            unGuerrero.perderVida(unGuerrero.cantidadDeArmas() * 10)
        }
    }
}

object lossarnach {
    method puedePasar(unGuerrero) = true

    method consecuencia(unGuerrero) {
        unGuerrero.ganarVida(unGuerrero.cantidadDeArmas() * 2)
    }
}

object caminoDeGondor {
    var property recorrido = [lebennin, minasTirith]

    method puedeRecorrer(unGuerrero) {
        return recorrido.all({ lugar => lugar.puedePasar(unGuerrero) })
    }

    method consecuencia(unGuerrero) {
        if (self.puedeRecorrer(unGuerrero)) {
            recorrido.forEach({ lugar => lugar.consecuencia(unGuerrero) })
        }
    }
}
