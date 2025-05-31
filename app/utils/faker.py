FAKE_MULTIPLIER = 1.25  # یعنی 40 گیگ واقعی → 50 گیگ فیک
ONE_GB = 1024 * 1024 * 1024

def get_fake_limit(real_bytes):
    real_gb = real_bytes / ONE_GB
    fake_gb = real_gb * FAKE_MULTIPLIER
    return int(fake_gb) * ONE_GB
