import { describe, expect, it } from "vitest";
import { formatSourceLabel, predicateLabel, predicatePhrase } from "./labels";

describe("predicateLabel", () => {
  it("humanises predicates", () => {
    expect(predicateLabel("held_by")).toBe("Held by");
    expect(predicateLabel("classified_as")).toBe("Classified as");
    expect(predicateLabel("has_name")).toBe("Name");
    expect(predicateLabel("possibly_same_as")).toBe("Possibly the same as");
  });
});

describe("predicatePhrase", () => {
  it("produces in-sentence phrases", () => {
    expect(predicatePhrase("held_by")).toBe("held by");
    expect(predicatePhrase("has_name")).toBe("has name");
    expect(predicatePhrase("possibly_same_as")).toBe("possibly the same as");
  });
});

describe("formatSourceLabel", () => {
  it("compacts URL labels to host and readable segment", () => {
    expect(formatSourceLabel("https://en.wikipedia.org/wiki/Rongorongo_text_C")).toBe(
      "en.wikipedia.org · Rongorongo text C",
    );
    expect(
      formatSourceLabel("https://www.britishmuseum.org/collection/object/E_Oc1869-1005-1"),
    ).toBe("britishmuseum.org · E Oc1869-1005-1");
    expect(formatSourceLabel("https://example.org/")).toBe("example.org");
  });

  it("compacts file paths to their basename", () => {
    expect(formatSourceLabel("docs/source-material/Moai Hoa Haka Nanaia")).toBe(
      "Moai Hoa Haka Nanaia",
    );
  });

  it("leaves ordinary labels unchanged", () => {
    expect(formatSourceLabel("British Museum: Moai")).toBe("British Museum: Moai");
    expect(formatSourceLabel("21_32571-1.jpg")).toBe("21_32571-1.jpg");
  });
});
