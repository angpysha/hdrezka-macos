import Alamofire
import Combine
import FactoryKit
import Foundation

struct Aria2RepositoryImpl: Aria2Repository {
    @Injected(\.session) private var session

    #if os(macOS)
        func call<D: Decodable & Sendable>(data: some Encodable) -> AnyPublisher<Aria2Response<D>, Error> {
            session.request(Aria2Service.call(data: data))
                .publishDecodable(type: Aria2Response<D>.self)
                .value()
                .tryMap { $0 }
                .eraseToAnyPublisher()
        }

        func multicall<D: Decodable & Sendable>(data: [some Encodable]) -> AnyPublisher<[Aria2Response<D>], Error> {
            session.request(Aria2Service.multicall(data: data))
                .publishDecodable(type: [Aria2Response<D>].self)
                .value()
                .tryMap { $0 }
                .eraseToAnyPublisher()
        }
    #else
        // tvOS stub - downloads not supported
        func call<D: Decodable & Sendable>(data _: some Encodable) -> AnyPublisher<Aria2Response<D>, Error> {
            Fail(error: NSError(domain: "Aria2", code: -1, userInfo: [NSLocalizedDescriptionKey: "Downloads not supported on tvOS"]))
                .eraseToAnyPublisher()
        }

        func multicall<D: Decodable & Sendable>(data _: [some Encodable]) -> AnyPublisher<[Aria2Response<D>], Error> {
            Fail(error: NSError(domain: "Aria2", code: -1, userInfo: [NSLocalizedDescriptionKey: "Downloads not supported on tvOS"]))
                .eraseToAnyPublisher()
        }
    #endif
}
