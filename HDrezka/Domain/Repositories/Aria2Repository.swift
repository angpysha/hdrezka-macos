import Combine

protocol Aria2Repository {
    func call<D: Decodable & Sendable>(data: some Encodable) -> AnyPublisher<Aria2Response<D>, Error>

    func multicall<D: Decodable & Sendable>(data: [some Encodable]) -> AnyPublisher<[Aria2Response<D>], Error>
}
