import Vapor

extension UUID {
    func authorize(to id: Self?) throws {
        if self != id {
            throw Abort(.unauthorized)
        }
    }
}
