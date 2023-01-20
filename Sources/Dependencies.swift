import Foundation
import OpenAI

public enum Dependencies {
  public static var openAI = OpenAI(apiToken: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!)
}
