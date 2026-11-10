// Queries the battery of a Logitech HID++ 2.0 device connected directly
// over Bluetooth (e.g. MX Master 3S) and prints "<percent> <charging>".
// Exits with 1 if no device answers.
#include <hidapi.h>
#include <stdio.h>
#include <string.h>

#define LOGI_VID 0x046d
#define HIDPP_USAGE_PAGE 0xff43
#define HIDPP_LONG 0x11
#define HIDPP_LONG_LEN 20
#define DEVICE_IDX 0xff
#define SW_ID 0x0a
#define TIMEOUT_MS 500

#define FEATURE_UNIFIED_BATTERY 0x1004
#define FEATURE_BATTERY_STATUS 0x1000

static int hidpp_call(hid_device* dev, unsigned char feature_idx,
                      unsigned char fn, const unsigned char* params,
                      int n_params, unsigned char* out) {
  unsigned char req[HIDPP_LONG_LEN] = { HIDPP_LONG, DEVICE_IDX, feature_idx,
                                        (unsigned char)((fn << 4) | SW_ID) };
  if (n_params > 0) memcpy(req + 4, params, n_params);
  if (hid_write(dev, req, sizeof(req)) < 0) return -1;

  unsigned char res[64];
  for (int tries = 0; tries < 10; tries++) {
    int n = hid_read_timeout(dev, res, sizeof(res), TIMEOUT_MS);
    if (n <= 0) return -1;
    if (res[0] != HIDPP_LONG || n < HIDPP_LONG_LEN) continue;
    // Error reply: feature index 0xff, echoing our feature/function
    if (res[2] == 0xff && res[3] == feature_idx && res[4] == req[3]) return -1;
    if (res[2] == feature_idx && res[3] == req[3]) {
      memcpy(out, res + 4, 16);
      return 0;
    }
  }
  return -1;
}

static int feature_index(hid_device* dev, unsigned short feature) {
  unsigned char params[2] = { feature >> 8, feature & 0xff };
  unsigned char out[16];
  if (hidpp_call(dev, 0x00, 0, params, 2, out) < 0 || out[0] == 0) return -1;
  return out[0];
}

static int query(hid_device* dev, int* percent, int* charging) {
  unsigned char out[16];
  int idx = feature_index(dev, FEATURE_UNIFIED_BATTERY);
  if (idx > 0) {
    if (hidpp_call(dev, idx, 1, NULL, 0, out) < 0) return -1;
    *percent = out[0];
    *charging = out[2] == 1 || out[2] == 2; // charging / slow charging
    return 0;
  }

  idx = feature_index(dev, FEATURE_BATTERY_STATUS);
  if (idx > 0) {
    if (hidpp_call(dev, idx, 0, NULL, 0, out) < 0) return -1;
    *percent = out[0];
    *charging = out[2] >= 1 && out[2] <= 3;
    return 0;
  }
  return -1;
}

int main(void) {
  if (hid_init() < 0) return 1;

  int found = 0, percent = 0, charging = 0;
  struct hid_device_info* devs = hid_enumerate(LOGI_VID, 0);
  for (struct hid_device_info* d = devs; d && !found; d = d->next) {
    if (d->usage_page != HIDPP_USAGE_PAGE) continue;
    hid_device* dev = hid_open_path(d->path);
    if (!dev) continue;
    found = query(dev, &percent, &charging) == 0;
    hid_close(dev);
  }
  hid_free_enumeration(devs);
  hid_exit();

  if (!found) return 1;
  printf("%d %d\n", percent, charging);
  return 0;
}
