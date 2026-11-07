// ==========================================
// ARSENAL (ARMAS)
// ==========================================

class Espada {
    var property multiplicador

    method poderOtorgado(unGuerrero) = multiplicador * unGuerrero.valorOrigen()
}

class Daga inherits Espada {
    override method poderOtorgado(unGuerrero) = super(unGuerrero) / 2
}

class Baculo {
    var property poder = 400

    method poderOtorgado(unGuerrero) = poder
}

class Hacha {
    var property largoMango 
    var property pesoHoja 

    method poderOtorgado(unGuerrero) = largoMango * pesoHoja
}

// ==========================================
// GUERREROS
// ==========================================

class Guerrero {
    var property vidaActual = 100
    var property armas = []
    var property elementos = []
    var property tactica 
    var property umbral 
    var property archienemigo
    var property mejoramigo 

    method vida() = vidaActual

    method cantidadDeArmas() = armas.size()

    method estaArmado() = !armas.isEmpty()

    method sumatoriaPoderArmas() = armas.sum({ arma => arma.poderOtorgado(self) })

    method cantidadDeElementos() = elementos.size()

    method cantidadDeElemento(nombreElemento) =
        elementos.count({ elemento => elemento == nombreElemento })

    method agregarArma(unArma) {
        armas.add(unArma)
    }

    method agregarElemento(unElemento) {
        elementos.add(unElemento)
    }

    method perderVida(cantidad) {
        vidaActual = 0.max(vidaActual - cantidad)
    }

    method ganarVida(cantidad) {
        vidaActual += cantidad
    }
  
    method poder (){}
    method valorOrigen() = 10 * self.cantidadDeArmas()

    // Polimorfismo con Grupo para recorrer zonas, caminos y regiones
    method todosCumplen(condicion) = condicion.apply(self)

    method algunoCumple(condicion) = condicion.apply(self)

    method aplicarConsecuencia(accion) {
        accion.apply(self)
    }

    method puedeAtravesar(unDestino) = unDestino.puedePasar(self)

    method atravesar(unDestino) {
        unDestino.atravesar(self)
    }
    
    method enfrentamiento (oponente){
    tactica.enfrentamiento(self, oponente)
    }
    method atacar (oponente){
        oponente.perderVida (self.poder()*0.10)
    }
    
    method leConvieneAtacar (oponente) = oponente.poder() <= umbral
    method estaVivo () = vidaActual > 0
    
    method armaMaspoderosa (){
        armas.max({arma => arma.poderOtorgado(self)})
    }
    method sacarArmamasPoderosa (){
        if (self.estaArmado()){
            armas.remove(self.armaMaspoderosa())
        }
    }
    method aplicarPenalidad(penalidad) {
        penalidad.aplicar(self)
    }
    method duplicarVida() {
    vidaActual = (vidaActual * 2).min(100)
}
    method tienemuchasArmas () = self.cantidadDeArmas() > 3
}

class Hobbit inherits Guerrero {
    override method poder() =
        vidaActual + self.cantidadDeElementos() * self.sumatoriaPoderArmas()
}

class Enano inherits Guerrero {
    var property factorDePoder 

    override method valorOrigen() = 20

    override method poder() =
        vidaActual + factorDePoder * self.sumatoriaPoderArmas()
}

object elfo {
    var property destrezaBase = 2
}

class Elfo inherits Guerrero {
    var property destrezaPropia 

    override method valorOrigen() = 25

    method destrezaBase() = elfo.destrezaBase()

    method destrezaBase(nuevoValor) {
        elfo.destrezaBase(nuevoValor)
    }

    method ganarDestreza(cantidad) {
        destrezaPropia += cantidad
    }

    override method poder() =
        vidaActual + (self.destrezaBase() + destrezaPropia) * self.sumatoriaPoderArmas()
}

class Humano inherits Guerrero {
    var property limitadorDePoder

    override method valorOrigen() = 15

    override method poder() =
        vidaActual + self.sumatoriaPoderArmas() / limitadorDePoder
}

class Maiar inherits Guerrero {
    var property factorBasico = 15
    var property factorBajoAmenaza = 300

    method tienePocaVida() = vidaActual < 10

    method factorActual() =
        if (self.tienePocaVida()) factorBajoAmenaza else factorBasico

    override method poder() =
        vidaActual * self.factorActual() + 2 * self.sumatoriaPoderArmas()
}

object gollum inherits Hobbit {
    override method poder() = super() / 2 }


object tomBombadil inherits Guerrero {
    override method poder() = 10000000

    override method cantidadDeArmas() = 100

    override method estaArmado() = true

    override method perderVida(cantidad) { }
}


// ==========================================
// GRUPOS DE GUERREROS
// ==========================================

class Grupo {
    var property guerreros = []

    method agregarGuerrero(unGuerrero) {
        guerreros.add(unGuerrero)
    }

    method todosCumplen(condicion) = guerreros.all(condicion)

    method algunoCumple(condicion) = guerreros.any(condicion)

    method aplicarConsecuencia(accion) {
        guerreros.forEach(accion)
    }

    method cantidadDeElemento(nombreElemento) =
        guerreros.sum({ guerrero => guerrero.cantidadDeElemento(nombreElemento) })

    method puedeAtravesar(unDestino) = unDestino.puedePasar(self)

    method atravesar(unDestino) {
        unDestino.atravesar(self)
    }
    method aplicarPenalidad(penalidad) {
        guerreros.forEach({ guerrero => guerrero.aplicarPenalidad(penalidad) })
    }
}


// ==========================================
// REQUERIMIENTOS DE ZONA
// ==========================================

object sinRequerimiento {
    method cumple(alguien) = true
}

class RequerimientoDeElemento {
    var property cantidad 
    var property elemento 

    method cumple(alguien) = alguien.cantidadDeElemento(elemento) >= cantidad
}

class RequerimientoDeGuerrero {
    var property condicion = { guerrero => true }

    method cumple(alguien) =
        alguien.algunoCumple({ guerrero => self.cumpleGuerrero(guerrero) })

    method cumpleGuerrero(unGuerrero) = condicion.apply(unGuerrero)
}

class RequerimientoMasDeArmas inherits RequerimientoDeGuerrero {
    var property cantidadMinima 

    override method cumpleGuerrero(unGuerrero) =
        unGuerrero.cantidadDeArmas() > cantidadMinima
}

class RequerimientoMasDePoder inherits RequerimientoDeGuerrero {
    var property poderMinimo

    override method cumpleGuerrero(unGuerrero) =
        unGuerrero.poder() > poderMinimo
}

class RequerimientoMasDeVida inherits RequerimientoDeGuerrero {
    var property vidaMinima 

    override method cumpleGuerrero(unGuerrero) =
        unGuerrero.vida() > vidaMinima
}

// ==========================================
// ZONAS, CAMINOS Y REGIONES
// ==========================================

class Zona {
    var property requerimiento = sinRequerimiento

    method puedePasar(alguien) =
        alguien.todosCumplen({ guerrero => self.puedePasarGuerrero(guerrero) }) &&
        requerimiento.cumple(alguien)

    method puedePasarGuerrero(unGuerrero) = true

    method consecuencia(alguien) {
        alguien.aplicarConsecuencia({ guerrero => self.consecuenciaGuerrero(guerrero) })
    }

    method consecuenciaGuerrero(unGuerrero) { }

    method validarPasar(alguien) {
        if (!self.puedePasar(alguien)) {
            self.error("No se cumplen las condiciones para atravesar la zona")
        }
    }

    method atravesar(alguien) {
        self.validarPasar(alguien)
        self.consecuencia(alguien)  
    }
}

class ZonaDePoder inherits Zona {
    var property poderMinimo = 1500

    override method puedePasarGuerrero(unGuerrero) = unGuerrero.poder() > poderMinimo
}

class ZonaArmada inherits Zona {
    var property vidaPerdida = 10

    override method puedePasarGuerrero(unGuerrero) = unGuerrero.estaArmado()

    override method consecuenciaGuerrero(unGuerrero) {
        unGuerrero.perderVida(vidaPerdida)
    }
}

object lebennin inherits ZonaDePoder {
}

object minasTirith inherits ZonaArmada {
}

object lossarnach inherits Zona {
    override method consecuenciaGuerrero(unGuerrero) {
        unGuerrero.ganarVida(unGuerrero.cantidadDeArmas() * 2)
    }
}

class Camino {
    var property zonas = [lebennin, minasTirith]
    var property penalidad
    method recorrido() = zonas

    method recorrido(nuevasZonas) {
        zonas = nuevasZonas
    }

    method puedePasar(alguien) = zonas.all({ zona => zona.puedePasar(alguien) })

    method puedeRecorrer(alguien) = self.puedePasar(alguien)

    method validarRecorrido(alguien) {
        if (!self.puedePasar(alguien)) {
            alguien.aplicarPenalidad(penalidad)
            self.error("No se cumplen las condiciones para recorrer el camino")
        }
    }

    method consecuencia(alguien) {
        zonas.forEach({ zona => zona.consecuencia(alguien) })
    }

    method atravesar(alguien) {
        self.validarRecorrido(alguien)
        self.consecuencia(alguien)
    }

    method recorrer(alguien) {
        self.atravesar(alguien)
    }
}

object caminoDeGondor inherits Camino {
}

class Region {
    var property zonas = [lossarnach, lebennin, minasTirith]
    var property camino = caminoDeGondor

    method puedePasar(alguien) = camino.puedePasar(alguien)

    method puedeRecorrer(alguien) = camino.puedeRecorrer(alguien)

    method atravesar(alguien) {
        camino.atravesar(alguien)
    }

    method recorrer(alguien) {
        camino.recorrer(alguien)
    }
}

object gondor inherits Region {
}

// parte 3

object tacticaAgil {
    method enfrentamiento (atacante,oponente) {
    oponente.perderVida ((atacante.poder() + 100 )* 0.10)
    if (oponente.estaVivo()) {
        oponente.atacar (atacante)
    }
    }
}


object tacticaDeResistencia {
     method enfrentamiento (atacante,oponente){
    atacante.perderVida((oponente.poder() * 0.10)/2)
    if(atacante.estaVivo()){
        atacante.atacar(oponente)
    }
     }
}

object tacticaCaruso {
    method enfrentamiento (atacante, oponente){
    if (atacante.leConvieneAtacar(oponente)) {
        atacante.atacar (oponente)
        if (oponente.estaVivo()){
            oponente.atacar(atacante)
        }
    }
    else {atacante.perderVida(10)}
}
}

object laCuatroTresTres {
    method enfrentamiento (atacante, oponente){
        atacante.atacar(oponente)
         if (oponente.estaVivo()) {
            atacante.atacar(oponente)
        }
         if (atacante.vidaActual() <= 60 && oponente.estaVivo()) {
          oponente.atacar(atacante)  
        }
    }
    }


class Penalidad {
    method aplicar(guerrero) {
    }
}

object muerte inherits Penalidad {
    override method aplicar(guerrero) {
        guerrero.vidaActual(0)
    }
}

object quitarArmamasPoderosa inherits Penalidad {
    override method aplicar(guerrero) {
        guerrero.sacarArmamasPoderosa()
    }
}

class PerderfracciondeVida inherits Penalidad {
    var property fraccion
    override method aplicar(guerrero) {
        guerrero.perderVida(guerrero.vidaActual() * fraccion)
    }
}

class PenalidadCombinada inherits Penalidad {
    var property penalidades = []
    method agregar(penalidad) {
        penalidades.add(penalidad)
    }
    override method aplicar(guerrero) {
        penalidades.forEach({ penalidad => penalidad.aplicar(guerrero) })
    }
}

class Anillo {
    var property dueño 
    method invocar () {
        dueño.duplicarVida()
        self.efectoAnillo()
    }
    method efectoAnillo (){
    }
}

class AnillodeFuego inherits Anillo {
    override method efectoAnillo (){
    dueño.archienemigo().perderVida(20)
    }
}

class AnilloMaldito inherits Anillo {
    override method efectoAnillo (){
        dueño.sacarArmamasPoderosa()
    }
}

class AnillodeAire inherits Anillo{
    override method efectoAnillo(){
        dueño.mejoramigo().ganarVida(30)
    }
}

object AnilloUnico inherits Anillo (dueño = gollum){
    override method efectoAnillo(){
        if (dueño.tienemuchasArmas){
            dueño.perderVida(20)
        } else dueño.perderVida(30)
    }
}