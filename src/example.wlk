/** 
 * Example Wollok object
 */
object baculo {
    var poderBase = 250

    method poderOtorgado(unGuerrero) {
        var poder = poderBase

        if (unGuerrero.tienePocaVida()) {
            poder = poderBase * 2
        }

        if (poder > 400) {
            poder = 400
        }

        return poder
    }
}

object espada {
    var magia = magiaElfica

    method poderOtorgado(unGuerrero) {
        return magia.poderOtorgado(unGuerrero) * 10
    }

    method cambiarMagia(nuevaMagia) {
        magia = nuevaMagia
    }
}

object magiaElfica {
    method poderOtorgado(unGuerrero) {
        return 25
    }
}

object magiaEnana {
    method poderOtorgado(unGuerrero) {
        return unGuerrero.vida() / 2
    }
}

object flechaBronce {

}

object flechaAluminio {

}


object flechaHierro {

}

object cajaFlechas {

}


object gandalf {
    var vidaActual = 100
    var multiplicadorDeVida = 15
    var armas = [baculo, espada, cajaFlechas]

    method vida() {
        return vidaActual
    }

    method tienePocaVida() {
        return vidaActual < 10
    }

    method poder() {
        var poderArmas = armas.sum({arma => arma.poderOtorgado(self)})

        if (self.tienePocaVida()) {
            multiplicadorDeVida = 200
        }

        return vidaActual * multiplicadorDeVida + poderArmas * 2
    }

    method cantidadDeArmas() {
        return armas.size()
    }

    method estaArmado() {
        return armas.size() > 0
    }

    method perderVida(cantidad) {
        vidaActual -= cantidad
    }

    method ganarVida(cantidad) {
        vidaActual += cantidad
    }
}

object lebennin {
    var cantidadGuardias = 3
    var poderMinimoParaPasar = 1000

    method puedePasar(unGuerrero) {
        if (cantidadGuardias > 3) {
            poderMinimoParaPasar = 1500
        }

        return unGuerrero.poder() > poderMinimoParaPasar
    }
    method consecuecia (unGuerrero){

    }
}


object minasTirith {
    method puedePasar(unGuerrero) {
        return unGuerrero.estaArmado()
    }

    method consecuencia(unGuerrero) {
        if (self.puedePasar(unGuerrero)) {
            unGuerrero.perderVida(
                unGuerrero.cantidadDeArmas() * 10
            )
        }
    }
}


object lossarnach {
    method puedePasar(unGuerrero) {
        return true
    }

    method consecuencia(unGuerrero) {
        unGuerrero.ganarVida(
            unGuerrero.cantidadDeArmas() * 2
        )
    }
}

object caminoDeGondor {
    var recorrido = [lebennin, minasTirith]

    method puedeRecorrer(unGuerrero) {
        return recorrido.all({
            lugar => lugar.puedePasar(unGuerrero)
        })
    }

    method consecuencia(unGuerrero) {
        if (self.puedeRecorrer(unGuerrero)) {
            recorrido.forEach({
                lugar => lugar.consecuencia(unGuerrero)
            })
        }
    }

    method cambiarRecorrido(nuevoRecorrido) {
        recorrido = nuevoRecorrido
    }
}

object tomBombadil {
    var vidaActual = 100

    method vida() {
        return vidaActual
    }

    method tienePocaVida() {
        return vidaActual < 10
    }

    method poder() {
        return 2000
    }

    method cantidadDeArmas() {
        return 100
    }

    method estaArmado() {
        return true
    }

    method perderVida(cantidad) {

    }

    method ganarVida(cantidad) {
        vidaActual += cantidad
    }
}
